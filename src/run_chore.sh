# Run chore to get reversals, good number & body size
# Tiffany Timbers, Oct 15, 2016

# Arguments:
# $1: path to directory holding the data

for zip in $1/*
do
  Chore --shadowless -p 0.027 -M 2 -t 20 -S -o N --plugin Reoutline::despike --plugin MeasureReversal::collect --plugin Respine $zip
  Chore --shadowless -p 0.027 -M 2 -t 20 -S -o emM -N all --plugin Reoutline::despike --plugin Respine $zip
done
