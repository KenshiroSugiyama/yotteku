const firebaseLogin = () => {
  const ui = firebaseui.auth.AuthUI.getInstance() || new firebaseui.auth.AuthUI(firebase.auth());
  const uiConfig = {
    callbacks: {
      signInSuccessWithAuthResult: (authResult, redirectUrl) => {
        authResult.user.getIdToken(true)
          .then((idToken) => { railsLogin(authResult.additionalUserInfo.isNewUser, idToken) })
          .catch((error)  => { console.log(`Firebase getIdToken failed!: ${error.message}`) });
        return false; // firebase側にログイン後はリダイレクトせず、railsへajaxでリクエストを送る
      },
      uiShown: () => { document.getElementById('loader').style.display = 'none' }
    },
    signInFlow: 'redirect',
    signInOptions: [
      firebase.auth.GoogleAuthProvider.PROVIDER_ID, // Google認証
      firebase.auth.GithubAuthProvider.PROVIDER_ID, // GitHub認証
    ],
  };
　# ログイン画面表示
  ui.start('#firebaseui-auth-container', uiConfig);
}

const csrfTokenObj = () => {
  return { "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr('content') };
}

const authorizationObj = (idToken) => {
  return { "Authorization": `Bearer ${idToken}` };
}

const railsLogin = (isNewUser, idToken) => {
  const url = isNewUser ? "/accounts" : "/login";
  const headers = Object.assign(csrfTokenObj(), authorizationObj(idToken));
  $.ajax({url: url, type: "POST", headers: headers})
    .done((data) => { console.log("Rails login!")      })
    .fail((data) => { console.log("Rails login failed!") });
}
