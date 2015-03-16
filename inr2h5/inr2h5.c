/**
 * INRIMAGE conversion to HDF5 (ITK)
 * (c) 2015 D. Béréziat
 *
 * All format are handled (-s -e -b -p -f -r).
 * For bit coding, we convert to byte coding using Inrimage
 * conversion convention. 
 *
 * TODO:
 *  - origins
 *  - frame by frame access
 *  - biais and scale
 *  - history
 *  - color palette (how is it with ITK ?)
 *  - H5Image
 *  - compression (see inactive by default)
 *
 * LIMITATIONS
 *  - no bit coding. It is possible with HDF5 (see BITFIELD datatype class), but I don't
 *    know for ITK...
 */

#include <hdf5.h>
#include <inrimage/image.h>
#include <stdlib.h>
#include <string.h>

int main( int argc, char **argv) {
  char name[128];
  struct image *nf;
  struct nf_fmt fmt;
  hid_t fd, space, type, data, group, itype;
  int i, nbytes;
  void *buf;
  
  hsize_t geom[4];
  long    ldims[3];
  double  ddims[9];
  
  inr_init( argc, argv, "", "", "");
  infileopt(name);

  nf = imagex_( name, "e", "", &fmt);
    
  /* create hdf5 structures */
  outfileopt(name);
  fd = H5Fcreate( name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT );

  /* Create Itk Directories */
  H5Gcreate( fd, "/ITKImage", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  H5Gcreate( fd, "/ITKImage/0", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /* Create Dimension dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate( fd, "/ITKImage/0/Dimension", H5T_STD_U64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  ldims[0] = fmt.NDIMX;
  ldims[1] = fmt.NDIMY;
  ldims[2] = fmt.NDIMZ;
  H5Dwrite( data, H5T_STD_U64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ldims);

  H5Dclose(data);
  H5Sclose(space);

  /* Create Directions dataset */
  geom[0] = 3;
  geom[1] = 3;
  space = H5Screate_simple( 2, geom, NULL);
  data = H5Dcreate( fd, "/ITKImage/0/Directions", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  for( i=0; i<9; i++) ddims[i] = 0;
  ddims[0] = ddims[4] = ddims[8] = 1;
  H5Dwrite( data, H5T_IEEE_F64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ddims);
  
  H5Dclose( data);
  H5Sclose( space);

  /* Meta données: on s'en sert pour l'historique, l'exposant, biais et echelle */
  H5Gcreate( fd, "/ITKImage/0/MetaData", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  if( fmt.TYPE != REELLE) {
    space = H5Screate( H5S_SCALAR);
    data = H5Dcreate( fd, "/ITKImage/0/MetaData/exponent", H5T_STD_I32LE, space,
		      H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    i = fmt.EXP > 0 ? fmt.EXP - 200 : -fmt.EXP - 200; 
    H5Dwrite( data, H5T_STD_I32LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, &i);
    H5Dclose( data);
    H5Sclose( space);

    /* TODO: biais et echelle */
  }
  
  
  /* Create Origin dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate( fd, "/ITKImage/0/Origin", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  /* FIXME: écrire les origines dans le H5 */
  H5Dclose( data);
  H5Sclose( space);

  /* Create Spacing dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate( fd, "/ITKImage/0/Spacing", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  ddims[0] = ddims[1] = ddims[2] = 1;
  H5Dwrite( data, H5T_IEEE_F64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ddims);

  H5Dclose( data);
  H5Sclose( space);
  
  /* Create VoxelData dataset (image data is here) */
  switch (fmt.TYPE) {
  case REELLE:
    nbytes = fmt.TYPE;

    switch(fmt.BSIZE) {
    case 4: itype = H5T_IEEE_F32LE; break;
    case 8: itype = H5T_IEEE_F64LE; break;
    default: imerror( 9, "Unsupported coding (TYPE=REELLE, BSIZE=%d)",fmt.BSIZE);
    }
    break;
  case FIXE:
  case PACKEE:
    nbytes = fmt.BSIZE < 0 ? (7-fmt.BSIZE)/8 : fmt.BSIZE;
    
    switch (nbytes) {
    case 1: itype = (fmt.EXP>0)?H5T_STD_U8LE:H5T_STD_I8LE; break;
    case 2: itype = (fmt.EXP>0)?H5T_STD_U16LE:H5T_STD_I16LE; break;
    case 4: itype = (fmt.EXP>0)?H5T_STD_U32LE:H5T_STD_I32LE; break;
    default:
      if( fmt.BSIZE > 0)
	imerror( 9, "Unsupported coding (TYPE=FIXE, BSIZE=%d)", fmt.BSIZE);      
    }
    break;
  }
  geom[0] = fmt.NDIMZ;
  geom[1] = fmt.NDIMY;
  geom[2] = fmt.NDIMX;
  geom[3] = fmt.NDIMV;
  space = H5Screate_simple( fmt.NDIMV == 1 ? 3 : 4, geom, NULL);
  data  = H5Dcreate( fd, "/ITKImage/0/VoxelData", itype, space,
		     H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /* Lecture complete, TODO: frame by frame */
  buf = (void *) malloc( nbytes*fmt.DIMX*fmt.DIMY);
  c_lect( nf, fmt.DIMY, buf);

  if( fmt.BSIZE < 0 && nbytes != 8*(-fmt.BSIZE)) {
    Fort_int icodi[2] = {fmt.BSIZE,FIXE}, icodo[2] = {nbytes,FIXE};

    /* Cas où le format est packé, on decompacte.
     * la routine fonctionne in-place car on commence par la fin ! */
    if( fmt.TYPE == PACKEE)
      c_unpkbt(buf, buf, fmt.DIMX*fmt.DIMY, -fmt.BSIZE);
    
    /* Dans ce cas, la conversion peut être réalisée in-place */
    c_cnvtbg( buf, buf, fmt.DIMX*fmt.DIMY, icodi, icodo, 0, 0);  // FIXME: fmt.EXP, fmt.EXP) is better ???;
  }  
  H5Dwrite( data, itype, space, H5S_ALL, H5P_DEFAULT, buf);

  /* Create VoxelType dataset */
  type = H5Tcopy (H5T_C_S1);
  H5Tset_size ( type, 10); /* FIXME: H5T_VARIABLE); */
    
  geom[0] = 1;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate( fd, "/ITKImage/0/VoxelType", type, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  if( itype == H5T_STD_U8LE)        H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "UCHAR");
  else if( itype == H5T_STD_U16LE)  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "UINT");
  else if( itype == H5T_STD_U32LE)  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "ULONG");
  else if( itype == H5T_STD_I8LE)   H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "CHAR");
  else if( itype == H5T_STD_I16LE)  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "INT");
  else if( itype == H5T_STD_I32LE)  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "LONG");    
  else if( itype == H5T_IEEE_F32LE) H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "FLOAT");
  else if( itype == H5T_IEEE_F64LE) H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, "DOUBLE");
  
  H5Dclose( data);
  H5Sclose( space);

  /* Create ITKVersion (est-ce utile ?) */

  H5Fclose( fd);
  fermnf_(&nf);
  
  return 0;
}
