import { Link } from 'react-router-dom'
import logo from '../assets/logo.png'
import fb_icon from '../assets/fb_icon.png'
import linked_icon from '../assets/linked_icon.png'
import x_icon from '../assets/x_icon.png'
function Footer(){
    return(
        <section className="flex flex-col items-center w-full px-4 justify-evenly h-100 bg-n-800 rounded-t-2xl">
            <div className="flex flex-col justify-between w-full h-70 ">
                <div className='flex justify-between w-full h-20'>
                    <Link to='/'>
                    <img src={logo} alt= "Logo" className='object-contain w-auto h-full' /> 
                    </Link>

                    <div className='items-center hidden md:flex md:gap-x-12'>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-50'>About us</Link>
                        <Link to="/services" className='font-semibold text-md font-grostek text-n-50'>Services</Link>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-50'>Use Cases</Link>
                        <Link to='#' className='font-semibold text-md font-grostek text-n-50'>Genuine Parts </Link>
                    </div>

                    <div className='flex items-center justify-between w-40'>
                        <Link to='/'>
                            <img src={x_icon} alt= "Logo" className='object-contain ' /> 
                        </Link>
                        <Link to='/'>
                            <img src={fb_icon} alt= "Logo" className='object-contain ' /> 
                        </Link>
                        <Link to='/'>
                            <img src={linked_icon} alt= "Logo" className='object-contain ' /> 
                        </Link>
                    </div>
                    
                </div>
                <div className='flex justify-between w-full h-40'>
                    <div className='flex flex-col justify-between h-full'>
                        <h2 className='px-2 py-1 text-xl font-semibold w-fit font-grostek bg-p-500 rounded-xl text-n-50'>Contact Us:</h2>
                        <p className='font-light text-md font-grostek text-n-50'>Email: DanhThanh@gofix.com</p>    
                        <p className='font-light text-md font-grostek text-n-50'>Phone: 0919-308-888</p> 
                        <p className='font-light text-md font-grostek text-n-50'>Address: Bitexco, 1st Distict, Ho Chi Minh City</p> 
                    </div>

                    <div className='hidden w-[calc(50%)] h-full bg-n-700 rounded-2xl md:flex md:justify-evenly md:items-center px-4'>
                        <input className='px-2 mx-4 tracking-wider border h-[35%] w-85 rounded-xl text-n-50 font-grostek border-n-50' placeholder='Email'></input>
                        <button className='font-semibold mx-4 tracking-wider h-[35%] w-85 bg-p-500 rounded-xl text-n-50 font-grostek hover:bg-transparent hover:border border-p-500'  type='button'>Subcribe to news</button>
                    </div>
                </div>
            </div> 

            <div className="flex items-end w-full h-20 border-t border-n-50 ">

                <p className='font-light text-md font-grostek text-n-50 '>© 2025 danhthanhGoFix. All Rights Reserved.</p>
            </div>
        </section>
    )
}export default Footer