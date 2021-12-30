test:
	rspec --format doc

lint:
	rubocop

fix-lint:
	rubocop -a