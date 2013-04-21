# Input: ~/.ssh/id_rsa.pub
read -p "Enter the full path of the public key to import: " publickeyfile
keypair=`basename $publickeyfile .pub`
echo "querying regions"
regions=$(ec2-describe-regions | cut -f2)

for region in $regions; do
  echo "importing public key for $region ..."
  ec2-import-keypair --region $region --public-key-file $publickeyfile $keypair
done
