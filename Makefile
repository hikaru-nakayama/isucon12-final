bench: mysql-slow.rotate
	~/bin/benchmarker --stage=prod --request-timeout=10s --initialize-request-timeout=60s

nginx.rotate:
	sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.old
	sudo systemctl reload nginx

nginx.log:
	sudo tail -f /var/log/nginx/access.log

nginx.alp:
	alp json \
		--sort sum -r \
		-m "/user/\w+/present/receive,/user/\w+/gacha/draw/\w+/\w+,/user/\w+/present/index/\w+,/user/\w+/card/addexp/\w+,/user/\w+/gacha/index,/user/\w+/item,/user/\w+/home,/admin/user/\w+,/user/\w+/reward,/user/\w+/card" \
		-o count,method,uri,min,avg,max,sum \
		< /var/log/nginx/access.log

mysql-slow.rotate:
	sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.old && sudo mysqladmin flush-logs

mysql-slow.log:
	sudo tail -f /var/log/mysql/mysql-slow.log

mysql-slow.dump:
	sudo mysqldumpslow /var/log/mysql/mysql-slow.log

mysql-slow.digest:
	sudo pt-query-digest /var/log/mysql/mysql-slow.log

service.status:
	sudo systemctl status isuconquest.ruby.service

mysql.status:
	sudo systemctl status mysql.service

nginx.stauts:
	sudo systemctl status nginx.service

service.restart:
	sudo systemctl restart isuconquest.ruby.service

service.log:
	sudo journalctl -u isuconquest.ruby.service

mysql.sh:
	sudo mysql -uroot isucon

deploy1:
	scp -r ./webapp/ruby isucon:~/webapp
	scp -r ./webapp/sql/init.sh isucon:~/webapp/sql
	scp -r ./webapp/sql/add_index.sql isucon:~/webapp/sql
	scp -r ./etc/mysql/mysqld.cnf isucon:/etc/mysql/mysql.conf.d
	scp -r ./etc/nginx/nginx.conf isucon:/etc/nginx
	scp -r ./Makefile isucon:~/Makefile
	ssh isucon "sudo systemctl restart mysql"
	ssh isucon "sudo systemctl restart nginx.service"
	ssh isucon "sudo systemctl daemon-reload"
	ssh isucon "sudo systemctl restart isuconquest.ruby.service"

edit:
	vim ./webapp/ruby/app.rb