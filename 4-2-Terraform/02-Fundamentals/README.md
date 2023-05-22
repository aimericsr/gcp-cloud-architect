https://www.packer.io
https://developer.hashicorp.com/packer/plugins/builders/googlecompute
https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax

force to recreate the ressource so that provisonners can run (run only when creating ressources)
terraform taint google_compute_instance.vm_instance

Provisioners can also be defined that run only during a destroy operation. 
These are useful for performing system cleanup, extracting data, etc.