# bin/sh -i

bin/rails db:setup 

rm ./tmp/pids/server.pid

foreman start -f Procfile.dev