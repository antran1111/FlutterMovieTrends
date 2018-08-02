part of app_movie;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  String _email;
  String _password;

  String _checkEmail;
  String _checkPassword;

  bool _validEmail = true;
  bool _validPassword = true;

  bool _inAsync = false;

  final formKey = new GlobalKey<FormState>();

  bool _validateFields() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  String _validateEmail(String value) {

    if (value.isEmpty) {
      setState(() {
        _inAsync = false;
      });
      return "Email can't be empty";
    }

    if (!_validEmail) {
      _validEmail = true;
      return _checkEmail;
    }

    return null;
  }

  String _validatePassword(String value) {

    if (value.isEmpty) {
      setState(() {
        _inAsync = false;
      });
      return "Password can't be empty";
    }

    if (!_validPassword) {
      _validPassword = true;
      return _checkPassword;
    }

    return null;
  }

  void _validateSubmit(BuildContext context) async {
    setState(() {
      _inAsync = true;
      _validEmail = true;
      _validPassword = true;
    });
    if (_validateFields()) {
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          {
            prefs.setString("email", _email);
            prefs.setString("password", _password);
            prefs.setString("uid", user.uid);

            LoginNavigator(context: context);
          }
        }
      } catch (exception) {
        ErrorCode error = Utils.getError(exception.toString());

        setState(() {
          if (error == ErrorCode.PASSWORD) {
            _validPassword = false;
            _checkPassword = "The password is invalid.";
          } else {
            _validPassword = true;
            _checkPassword = null;
          }

          if (error == ErrorCode.EMAIL) {
            _validEmail = false;
            _checkEmail = "The email doesn't exists in the system.";
          } else {
            _validEmail = true;
            _checkEmail = null;
          }

          if (error == ErrorCode.FORMAT) {
            _validEmail = false;
            _checkEmail = "The email address is badly formatted.";
          }

          _validateFields();

          _inAsync = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.checkLoginState(context);
    return Stack(
      children: <Widget>[
        getBackground(),
        getTitle(),
        ProgressDialog(
          child: getLoginForm(),
          inAsync: _inAsync,
        ),
      ],
    );
  }

  Widget getBackground() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              "assets/movie_bg.png",
              fit: BoxFit.fitHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(top: 50.0, left: 20.0),
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.9,
              child: Text(
                "Movie Trends",
                style: TextStyle(
                  fontFamily: 'Movie',
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getLoginForm() {
    return Stack(
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getEmailForm(),
              getPasswordForm(),
            ],
          ),
        ),
        getLoginButton(),
      ],
    );
  }

  Widget getLoginButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 40.0, left: 10.0, right: 10.0),
        child: MaterialButton(
          text: "LOGIN",
          color: Colors.redAccent,
          onTap: () {
            _validateSubmit(context);
          },
        ),
      ),
    );
  }

  Widget getEmailForm() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: Colors.white,
      ))),
      margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Material(
        color: Colors.transparent,
        child: TextFormField(
          style: TextStyle(
            color: Colors.white,
          ),
          validator: _validateEmail,
          onSaved: (value) => _email = value,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
        ),
      ),
    );
  }

  Widget getPasswordForm() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Material(
        color: Colors.transparent,
        child: TextFormField(
          style: TextStyle(
            color: Colors.white,
          ),
          validator: _validatePassword,
          onSaved: (value) => _password = value,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
        ),
      ),
    );
  }
}
