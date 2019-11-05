require 'sinatra'
require 'oauth2'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

CALLBACK_PATH = '/auth/callback'

get '/' do
  erb :index
end

get '/auth' do
  state = params.transform_keys(&:to_sym)
  scope = state.delete(:scope)
  redirect oauth2(state).auth_code.authorize_url(redirect_uri: redirect_uri, scope: scope, state: state.to_json)
end

get CALLBACK_PATH do
  state = JSON.parse(params.fetch('state')).transform_keys(&:to_sym)
  code = params.fetch('code')
  begin
    access_token = oauth2(state).auth_code.get_token(code, redirect_uri: redirect_uri)
    erb "<p>Your token: #{access_token.token}</p>"
  rescue OAuth2::Error => e
    erb %(<p>#{e}</p>)
  end
end

def oauth2(client_id:, client_secret:, authorize_url:, token_url:)
  OAuth2::Client.new(client_id, client_secret, authorize_url: authorize_url, token_url: token_url)
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path  = CALLBACK_PATH
  uri.query = nil
  uri.to_s
end

__END__

@@ index

<div>
  <form action="/auth">
    <label for="client_id">client_id:</label>
    <input id="client_id" name="client_id" type="text" />

    <label for="client_secret">client_secret:</label>
    <input id="client_secret" name="client_secret" type="text" />

    <label for="authorize_url">authorize_url:</label>
    <input id="authorize_url" name="authorize_url" type="text" />

    <label for="token_url">token_url:</label>
    <input id="token_url" name="token_url" type="text" />

    <label for="scope">scope:</label>
    <input id="scope" name="scope" type="text" />

    <input type="submit" />
  </form>
</div>

<p>redirect_uri: <%= redirect_uri %></p>

@@ layout

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
  </head>
  <body>
    <%= yield %>
  </body>
</html>
