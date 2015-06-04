echo "Unit tests using $(inrinfo | head -1)"
echo "==="
echo ""

case $(inrinfo | head -1) in
    Inrimage*) ext=inr;;
    Heimdali*) ext=h5;;
esac
