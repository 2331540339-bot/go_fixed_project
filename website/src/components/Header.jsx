import { Link } from 'react-router-dom'
import logo from '../assets/logo.png'
import Login from '../components/Login'
import { useEffect, useState } from 'react'
import LoginCheck from "./LoginCheck";
function Header({onAuthChange}){

    const [isClicked, setIsClicked] = useState(false);
    const [loginCheck, setLoginCheck] = useState(false);
    const handleLogin = () => {
        setIsClicked(true);
        onAuthChange();
        console.log(isClicked);
    };

    const handleLogout = () => {
        localStorage.removeItem('token');
        setLoginCheck(false);
        onAuthChange();
    }
    useEffect(() =>{
        setLoginCheck(LoginCheck)
        console.log("Trạng thái đăng nhập:", loginCheck);
    },[])
    return(
        
        
        <>
            <nav className='flex justify-between w-full px-10 py-3 h-30'>
                <Link to='/'>
                    <img src={logo} alt= "Logo" className='object-contain w-auto h-full' /> 
                </Link>

                <div className='items-center hidden md:flex md:gap-x-12'>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-800'>About us</Link>
                        <Link to="/services" className='font-semibold text-md font-grostek text-n-800'>Services</Link>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-800'>Use Cases</Link>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-800'>Genuine Parts </Link>
                </div>

                <div className="items-center hidden md:flex md:gap-x-12 md:mr-5" >
                    {loginCheck?
                        <Link onClick={() => handleLogout()} className='inline-block px-4 py-2 font-bold border font-grostek text-n-800 border-p-500 rounded-xl hover:bg-p-500 hover:text-n-50'>Đăng xuất<span>&rarr;</span></Link>
                        :
                        <Link onClick={() => handleLogin()} className='inline-block px-4 py-2 font-bold border font-grostek text-n-800 border-p-500 rounded-xl hover:bg-p-500 hover:text-n-50'>Đăng nhập <span>&rarr;</span></Link>
                    }
                </div>
                

                <div className="flex md:hidden">
                    <button type="button" command="show-modal" commandfor="mobile-menu" className="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700">
                        <span className="sr-only">Open main menu</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" data-slot="icon" aria-hidden="true" className="size-6">
                            <path d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                    </button>
                </div>
            </nav>

            <div>
                {isClicked?<Login onClose = {() => setIsClicked(false)} onSuccess = {() => setLoginCheck(true)} onAuth = {() => onAuthChange()}/>:console.log("no")}
            </div>
        </>
        
    )
}export default  Header