/**
 * HDF5 conversion to INRIMAGE
 * (c) 2015 D. Béréziat
 *
 * convert only 1,2,4 signed or unsigned with exponent
 * and float simple/double precision
 * 
 * TODO/FIXME
 * - lecture des HDF5 image
 * - palette ??? C'est comment dans ITK ???
 * - history, exponent, bias, scale
 */

#include <inrimage/image.h>
#include <hdf5.h>
#include <stdlib.h>

extern int debug_;
  
int main( int argc, char **argv) {
  char name[256];
  
  inr_init( argc, argv, "0.1", "h5input [-i] [-d] [output | -] ",
	    "Convert ITK/HDF5 image to Inrimage. Options are:\n"
	    "\t-i: just print image header (in inrimage format)\n"
	    "\t-d: select ITK directory (0 is default)\n");

  /* no HDF5 message error unless -D option is specified */
  if( !debug_) H5Eset_auto (  0, (H5E_auto2_t) NULL, NULL);
    
  infileopt(name);
  if( H5Fis_hdf5(name)) {
    int dir = 0;
    char path[128];
    hid_t
      fd,  /* hdf5 file descriptor */
      set, /* hdf5 dataset descriptor */
      type, /* hdf5 type descriptor */
      space; /* hdf5 dataspace descriptor */
    hid_t mem_type_id;
    hid_t set2;
    double origins[3];
    
    struct nf_fmt format;
    
    hsize_t dims[4], maxdims[4];
    int i;
    void *data;

    igetopt1("-d","%d",&dir); /* as in tiff2inr */
    sprintf( path, "/ITKImage/%d/VoxelData", dir);
    
    fd = H5Fopen( name, H5F_ACC_RDONLY, H5P_DEFAULT);

    set = H5Dopen2(fd, path, H5P_DEFAULT);
    if( set < 0) imerror( 11, "Error: not an ITK/HDF5 file\n");
    
    type = H5Dget_type(set);
    format.BSIZE =  H5Tget_size( type);
    switch ( H5Tget_class(type) ) {
    case H5T_INTEGER:
      format.EXP = H5Tget_sign(type) ? -200 : 200;      
      format.TYPE = FIXE;
      switch (format.BSIZE) {
      case 1:
	mem_type_id = (format.EXP < 0) ? H5T_STD_I8LE : H5T_STD_U8LE;
	break;
      case 2:
	mem_type_id = (format.EXP < 0) ? H5T_STD_I16LE : H5T_STD_U16LE;
	break;
      case 4:
	mem_type_id = (format.EXP < 0) ? H5T_STD_I32LE : H5T_STD_U32LE;
	break;
      default:
	imerror(9,"Error: unsupported coding format (%d bytes per value)\n", format.BSIZE);
      }
      break;
    case H5T_FLOAT:
      format.TYPE = REELLE;
      switch (format.BSIZE) {
      case 4:
	mem_type_id = H5T_IEEE_F32LE;
	break;
      case 8:
	mem_type_id = H5T_IEEE_F64LE;
	break;
      default:
	imerror(9,"Error: unsupported float format\n");
      }
      break;
    default:
      imerror( 11, "Error: unsupported class type (%d)\n", H5Tget_class(type));
    } 


    
    space = H5Dget_space( set);
    H5Sget_simple_extent_dims( space, dims, maxdims) ;
#define h5_z 0
#define h5_y 1
#define h5_x 2
#define h5_v 3
    
    format.NDIMZ = dims[h5_z];
    format.NDIMX = dims[h5_x];
    format.NDIMY = dims[h5_y];
    format.NDIMV = H5Sget_simple_extent_ndims( space) == 3 ? 1 : dims[h5_v];
    format.DIMX = format.NDIMX * format.NDIMV;
    format.DIMY = format.NDIMY * format.NDIMZ;

    /* Origins */
    sprintf( path, "/ITKImage/%d/Origin", dir);
    set2 = H5Dopen2(fd, path, H5P_DEFAULT);
    H5Dread(set2, H5T_STD_U64LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, origins);
    H5Dclose(set2);
    format.offsets[0] = (int)origins[0] ; /* pas sur des indices -> vérifier avec Dimension */
    format.offsets[1] = (int)origins[1] ; /* pas sur des indices */
    format.offsets[2] = (int)origins[2] ; /* pas sur des indices */

    /* Metadata (scale,bias,exponent,history) */
    if( format.TYPE != REELLE) {
      sprintf( path, "/ITKImage/%d/MetaData/exponent", dir);
      set2 = H5Dopen2(fd, path, H5P_DEFAULT);
      if( set2) {     /* FIXME: error handling verbose */
	int exponent;
	H5Dread(set2, H5T_STD_I32LE, H5S_ALL, H5S_ALL, H5P_DEFAULT, &exponent);
	if( format.EXP > 0)
	  format.EXP = format.EXP + exponent;
	else
	  format.EXP = format.EXP - exponent;
      }
    }
    
    
    if( igetopt0("-i")) {
      /* On pourra aussi imprimer les origines , man prtnf */
      c_wrfmg( format.lfmt, 1+2);
      H5Dclose(set);
      H5Fclose(fd);
      return 0;
    }

    /*
     * Conversion to Inrimage
     */

    outfileopt( name);
    struct image *nf = imagex_( name, "c", "", &format);
    
    /* The fastest way is to load the full h5file in memory */    
    data = (void *) malloc( format.BSIZE * H5Sget_simple_extent_npoints(space));
    if( data) {
      H5Dread( set, mem_type_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, data);    
      c_ecr( nf, format.DIMY, data);
    } else {
      /* Not enough memory to hold the image ? We work frame by frame ... */
      hsize_t offset[4];
      hsize_t count[4];
      int iz;
      hid_t mem;
      
      offset[h5_z] = 0;
      offset[h5_y] = 0;
      offset[h5_x] = 0;
      offset[h5_v] = 0;
      
      count[h5_z]  = 1;
      count[h5_y]  = format.NDIMY;
      count[h5_x]  = format.NDIMX;
      count[h5_v]  = format.NDIMV;
      
      mem = H5Screate_simple(4,count,NULL);   
      H5Sselect_hyperslab( mem, H5S_SELECT_SET, offset, NULL, 
			   count, NULL);
      
      data = (void *)malloc( format.BSIZE * format.DIMX * format.NDIMY);
      if( !data) imerror( 8, "Not enough memory!");
      
      for( iz = 0; iz < format.NDIMZ; iz ++) {
	offset[h5_z] = iz;
	H5Sselect_hyperslab( space, H5S_SELECT_SET, offset, NULL, count, NULL);
	H5Dread( set, mem_type_id, mem, space, H5P_DEFAULT, data);
	c_ecr( nf, format.NDIMY, data);
      }
    }
    
    H5Dclose(set);
    H5Fclose(fd);
    fermnf_(&nf);
    free(data);
    
  } else
      imerror( 11, "Error: not an HDF5 file\n");
  
  return 0;
}
