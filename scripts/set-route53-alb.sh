#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?}"
: "${HOSTED_ZONE_ID:?}"
: "${DOMAIN_NAME:?}"

INGRESS_ADDRESS="$(
  kubectl get ingress auspost-health -n "${NAMESPACE:-auspost-prod}" \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
)"

test -n "$INGRESS_ADDRESS"

cat >/tmp/route53-alias.json <<EOF
{
  "Comment": "Alias ${DOMAIN_NAME} to AusPost application ALB",
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "${DOMAIN_NAME}",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "Z1GM3ZHC3K5L2Z",
        "DNSName": "${INGRESS_ADDRESS}",
        "EvaluateTargetHealth": true
      }
    }
  }]
}
EOF

# The ALB hosted-zone ID is region/controller dependent. Resolve it from
# the ELB API rather than relying on a hard-coded value.
ALB_ZONE_ID="$(
  aws elbv2 describe-load-balancers \
    --region "$AWS_REGION" \
    --query "LoadBalancers[?DNSName=='${INGRESS_ADDRESS}'].CanonicalHostedZoneId | [0]" \
    --output text
)"

jq --arg zone "$ALB_ZONE_ID" \
  '.Changes[0].ResourceRecordSet.AliasTarget.HostedZoneId=$zone' \
  /tmp/route53-alias.json >/tmp/route53-alias-final.json

aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file:///tmp/route53-alias-final.json

echo "DNS configured: https://${DOMAIN_NAME}/health"
