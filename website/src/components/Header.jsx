import { Link } from 'react-router-dom'
import logo from '../assets/logo.png'

function Header(){
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

                <div class="hidden md:flex items-center md:gap-x-12 md:mr-5" >
                    <a href='#' className='inline-block px-4 py-2 font-bold border font-grostek text-n-800 border-p-500 rounded-xl hover:bg-p-500 hover:text-n-50 '>Login here <span>&rarr;</span></a>
                </div>
                

                <div class="flex md:hidden">
                    <button type="button" command="show-modal" commandfor="mobile-menu" class="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700">
                        <span class="sr-only">Open main menu</span>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" data-slot="icon" aria-hidden="true" class="size-6">
                            <path d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" stroke-linecap="round" stroke-linejoin="round" />
                        </svg>
                    </button>
                </div>
            </nav>
        </>
        
    )
}export default  Header