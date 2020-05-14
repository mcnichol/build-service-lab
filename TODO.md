Setup Dependency: kubectl `brew install kubectl`

If leveraging:
* GKE == gcloud `brew cask install google-cloud-sdk`
* PKS == pks  Get from network.pivotal.io
* TKG == ?
* EKS == ?
* AKS == ?
* KIND == kind `brew install kind` (Is this even possible due to networking pains?)
* Worth setting up Harbor or Private Registry
    * Batteries included Docker Hub is convenient

* Image Registry Certificate Setup
We can check if certs cover the domain
openssl crl2pkcs7 -nocrl -certfile mycertificate.cer | openssl pkcs7 -print_certs -noout
