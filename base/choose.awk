# External variables:
# l: Line number to extract
# f: Field number to extract

FNR == l { print($f) }
