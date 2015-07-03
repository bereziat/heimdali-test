echo "Unit tests using $(inrinfo | head -1)"
echo "==="
echo ""

case $(inrinfo | head -1) in
    Inrimage*) ext=inr; fmt='-f=';;
    Heimdali*) ext=h5;  fmt='-f ';;
esac
