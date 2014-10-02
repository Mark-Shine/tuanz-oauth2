# name: Weibo login
# about: Authenticate with discourse with tuan.
# version: 0.1.0
# author: Erick Guan

gem 'omniauth-tuanz-oauth2', '0.3.0'

class TuanzAuthenticator < ::Auth::Authenticator

  def name
    'tuanz'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    credentials = auth_token[:credentials]
    email = auth_token[:extra][:email]
    raw_info = auth_token[:extra][:raw_info]
    name = data['name']
    username = data['nickname']
    tuanz_uid = auth_token[:uid]

    current_info = ::PluginStore.get('tuanz', "tuanz_uid_#{tuanz_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.username = username
    result.email = email
    result.extra_data = { tuanz_uid: tuanz_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    tuanz_uid = auth[:uid]
    ::PluginStore.set('tuanz', "tuanz_id_#{tuanz_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :tuanz, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.tuanz_client_id
      strategy.options[:client_secret] = SiteSetting.tuanz_client_secret
    }
  end
end

auth_provider :frame_width => 920,
              :frame_height => 800,
              :authenticator => TuanzAuthenticator.new,
              :background_color => 'rgb(230, 22, 45)'

register_css <<CSS

.btn-social.tuanz:before {
  font-family: FontAwesome;
  content: "\\f18a";
}

CSS
