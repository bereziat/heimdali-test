#include <hdf5.h>

void write_string( hid_t fd, char *path, char **str);
void write_scalar( hid_t fd, char *path, hid_t type, void *buf);

