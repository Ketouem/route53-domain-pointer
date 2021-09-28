route53-domain-pointer
===

Update a route53 record set with the current public IP address. Can be useful when you want to access your home resources and your ISP keep changing your IP address.

# Requirements

- [aws-cli](https://aws.amazon.com/cli/)
- [curl](https://curl.se/)

# Usage

Using this tool implies that you have AWS credentials set up either under `~/.aws/credentials` or by using environment variables, more info in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

`./route53_domain_pointer.sh [-h] DOMAIN_NAME ZONE_ID`

Parameters:
- `DOMAIN_NAME`: domain name handled by route53
- `ZONE_ID`: route53 zone id of the record set.

Options:
- `h`: display help message.
