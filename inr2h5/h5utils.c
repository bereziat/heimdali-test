#include "h5utils.h"

void write_string( hid_t fd, char *path, char **str) {
  hid_t type, space, data;
  hsize_t geom = 1 , maxg = 1;

  type =  H5Tcopy( H5T_C_S1);
  H5Tset_size( type, H5T_VARIABLE);
  type = H5Tcopy( type);
  
  space = H5Screate_simple(1,&geom,&maxg);
  data = H5Dcreate( fd, path, type, space,
		    H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, str);
  H5Dclose(data);
  H5Dclose(space);
}

void write_scalar( hid_t fd, char *path, hid_t type, void *buf) {
  hid_t space, data;

  space = H5Screate( H5S_SCALAR);
  data = H5Dcreate( fd, path, type, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
  H5Dwrite( data, type, H5S_ALL, H5S_ALL, H5P_DEFAULT, buf);
  H5Dclose( data);
  H5Sclose( space);
}
