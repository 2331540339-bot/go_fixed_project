function LoginCheck(){
    let loginCheck = false;
    localStorage.getItem('token') != null? loginCheck =true:loginCheck = false;
    return loginCheck
}; export default LoginCheck