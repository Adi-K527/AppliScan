locals {
  envs = {
    for tuple in regexall("(.*)=(.*)", file("../../.env")) : tuple[0] => chomp(tuple[1]) 
  }
}