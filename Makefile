.PHONY: lambda.zip

lambda.zip:
	@rm -f $@
	@bundle install --deployment
	@zip -r $@ lambda.rb app vendor

clean:
	rm -rf .bundle lambda.zip vendor
