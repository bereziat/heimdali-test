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
 *  - history [OK but discuss]
 *  - color palette (how is it with ITK ?)
 *  - H5Image
 *  - compression (see inactive by default)
 *
 * LIMITATIONS
 *  - no bit coding. It is possible with HDF5 (see BITFIELD datatype class), but I don't
 *    know for ITK...
 */

#include "h5utils.h"
#include <inrimage/image.h>
#include <stdlib.h>
#include <string.h>

extern int debug_;

int main( int argc, char **argv) {
  char name[128], *str;
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

  /* no HDF5 message error unless -D option is specified */
  if( !debug_) H5Eset_auto2 (  0, (H5E_auto2_t) NULL, NULL);
  
  nf = imagex_( name, "e", "", &fmt);
    
  /* create hdf5 structures */
  outfileopt(name);
  fd = H5Fcreate( name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT );

  /* Create Itk Directories */
  H5Gcreate2( fd, "/ITKImage", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  H5Gcreate2( fd, "/ITKImage/0", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /* Create Dimension dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate2( fd, "/ITKImage/0/Dimension", H5T_STD_U64LE, space,
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
  data = H5Dcreate2( fd, "/ITKImage/0/Directions", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  for( i=0; i<9; i++) ddims[i] = 0;
  ddims[0] = ddims[4] = ddims[8] = 1;
  H5Dwrite( data, H5T_IEEE_F64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ddims);  
  H5Dclose( data);
  H5Sclose( space);

  /* Meta données: on s'en sert pour l'historique, l'exposant, biais et echelle */
  H5Gcreate2( fd, "/ITKImage/0/MetaData", H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  if( fmt.TYPE != REELLE) {
    i = fmt.EXP > 0 ? fmt.EXP - 200 : -fmt.EXP - 200; 
    write_scalar ( fd, "/ITKImage/0/MetaData/exponent", H5T_STD_I32LE, &i);
    // FIXME: if scale is defined, EXP is ignored.
    write_scalar ( fd, "/ITKImage/0/MetaData/scale", H5T_IEEE_F32LE, &fmt.scale);
    // FIXME: Only if BIAS= is found
    write_scalar ( fd, "/ITKImage/0/MetaData/bias", H5T_IEEE_F32LE, &fmt.bias);
    

    /* Historique/Commentaires/Clés */
    {
      int len;
      char *str;

      // FIXME:
      len  = strlen("#*[H]*<1> ");
      for( i=0; i<argc; i++)
	len += strlen(argv[i]) + 1;
      str = malloc( len);
      strcpy( str, "#*[H]*<1> ");

      for( i=0; i<argc; i++) {
	strcat( str, argv[i]);
	if( i < argc - 1) strcat ( str, " ");
      }
      write_string( fd, "/ITKImage/0/MetaData/history", &str);
    }
  }
  
  
  /* Create Origin dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate2( fd, "/ITKImage/0/Origin", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  /* FIXME: écrire les origines dans le H5 */
  H5Dclose( data);
  H5Sclose( space);

  /* Create Spacing dataset */
  geom[0] = 3;
  space = H5Screate_simple( 1, geom, NULL);
  data = H5Dcreate2( fd, "/ITKImage/0/Spacing", H5T_IEEE_F64LE, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  ddims[0] = ddims[1] = ddims[2] = 1;
  H5Dwrite( data, H5T_IEEE_F64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, ddims);
  H5Dclose( data);
  H5Sclose( space);
  
  /* Create VoxelData dataset (image data is here) */
  switch (fmt.TYPE) {
  case REELLE:
    nbytes = fmt.BSIZE;

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
  data  = H5Dcreate2( fd, "/ITKImage/0/VoxelData", itype, space,
		     H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);

  /* Lecture complete, TODO: frame by frame */
  buf = (void *) i_malloc( nbytes*fmt.DIMX*fmt.DIMY);
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
  H5Dclose( data);
  H5Dclose( space);
  
  /* Create VoxelType dataset */
  str = (char*)malloc(7);
  *str = '\0';
  if( itype == H5T_STD_U8LE)        strcpy( str, "UCHAR");
  else if( itype == H5T_STD_U16LE)  strcpy( str, "UINT");
  else if( itype == H5T_STD_U32LE)  strcpy( str, "ULONG");
  else if( itype == H5T_STD_I8LE)   strcpy( str, "CHAR");
  else if( itype == H5T_STD_I16LE)  strcpy( str, "INT");
  else if( itype == H5T_STD_I32LE)  strcpy( str, "LONG");    
  else if( itype == H5T_IEEE_F32LE) strcpy( str, "FLOAT");
  else if( itype == H5T_IEEE_F64LE) strcpy( str, "DOUBLE");
  write_string( fd, "/ITKImage/0/VoxelType", &str);

  /* Create ITKVersion dataset */
  strcpy( str, "4.8.0");
  write_string( fd, "/ITKVersion", &str);


  H5Fclose( fd);
  fermnf_(&nf);
  
  return 0;
}
