type IPSet::Type = Enum[
  'hash:ip',
  'hash:ip,port',
  'hash:ip,port,ip',
  'hash:ip,port,net',
  'hash:ip,mark',
  'hash:net',
  'hash:net,net',
  'hash:net,iface',
  'hash:net,port',
  'hash:net,port,net',
  'hash:mac',
]
