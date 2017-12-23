rm PeerAdmin@chainedbids-network*
rm alice@chainedbids-network
rm bob@chainedbids-network


composer card create -p profiles/connection-people-only.json -u PeerAdmin \
    -c crypto-config/peerOrganizations/people.chainedbids.uva.es/users/Admin@people.chainedbids.uva.es/msp/signcerts/Admin@people.chainedbids.uva.es-cert.pem \
    -k crypto-config/peerOrganizations/people.chainedbids.uva.es/users/Admin@people.chainedbids.uva.es/msp/keystore/*sk -r PeerAdmin -r ChannelAdmin

composer card create -p profiles/connection-people.json -u PeerAdmin \
    -c crypto-config/peerOrganizations/people.chainedbids.uva.es/users/Admin@people.chainedbids.uva.es/msp/signcerts/Admin@people.chainedbids.uva.es-cert.pem \
    -k crypto-config/peerOrganizations/people.chainedbids.uva.es/users/Admin@people.chainedbids.uva.es/msp/keystore/*sk -r PeerAdmin -r ChannelAdmin

composer card create -p profiles/connection-firms-only.json -u PeerAdmin -c \
    crypto-config/peerOrganizations/firms.chainedbids.uva.es/users/Admin@firms.chainedbids.uva.es/msp/signcerts/Admin@firms.chainedbids.uva.es-cert.pem \
    -k crypto-config/peerOrganizations/firms.chainedbids.uva.es/users/Admin@firms.chainedbids.uva.es/msp/keystore/*sk -r PeerAdmin -r ChannelAdmin

composer card create -p profiles/connection-firms.json -u PeerAdmin \
    -c crypto-config/peerOrganizations/firms.chainedbids.uva.es/users/Admin@firms.chainedbids.uva.es/msp/signcerts/Admin@firms.chainedbids.uva.es-cert.pem \
    -k crypto-config/peerOrganizations/firms.chainedbids.uva.es/users/Admin@firms.chainedbids.uva.es/msp/keystore/*sk -r PeerAdmin -r ChannelAdmin

composer card delete -n PeerAdmin@chainedbids-network-people
composer card delete -n PeerAdmin@chainedbids-network-people-only
composer card delete -n PeerAdmin@chainedbids-network-firms
composer card delete -n PeerAdmin@chainedbids-network-firms-only
composer card delete -n alice@chainedbids-network
composer card delete -n bob@chainedbids-network

composer card import -f PeerAdmin@chainedbids-network-people.card
composer card import -f PeerAdmin@chainedbids-network-people-only.card
composer card import -f PeerAdmin@chainedbids-network-firms.card
composer card import -f PeerAdmin@chainedbids-network-firms-only.card

composer runtime install -c PeerAdmin@chainedbids-network-people-only -n chainedbids-network
composer runtime install -c PeerAdmin@chainedbids-network-firms-only -n chainedbids-network

rm -rf alice
composer identity request -c PeerAdmin@chainedbids-network-people-only -u admin -s adminpw -d alice

rm -rf bob
composer identity request -c PeerAdmin@chainedbids-network-firms-only -u admin -s adminpw -d bob

composer network start -c PeerAdmin@chainedbids-network-people -a ../chainedbids-network@0.0.1.bna \
    -o endorsementPolicyFile=profiles/endorsement-policy.json \
    -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem

composer card create -p profiles/connection-people.json -u alice -n chainedbids-network -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@chainedbids-network.card
composer network ping -c alice@chainedbids-network

composer card create -p profiles/connection-firms.json -u bob -n chainedbids-network -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@chainedbids-network.card
composer network ping -c bob@chainedbids-network