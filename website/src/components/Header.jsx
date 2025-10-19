import logo from '../assets/logo.png'

function Header(){
    return(

        <>
            <nav className='  h-30 w-full flex justify-between px-10 py-3 '>
                <a href='#'>
                    <img src={logo} alt= "Logo" className='h-full w-auto object-contain' /> 
                </a>

                <div className='hidden md:flex items-center md:gap-x-12'>
                        <a href='#' className='text-md font-grostek text-n-800 font-semibold'>About us</a>
                        <a href='#' className='text-md font-grostek text-n-800 font-semibold'>Services</a>
                        <a href='#' className='text-md font-grostek text-n-800 font-semibold'>Use Cases</a>
                        <a href='#' className='text-md font-grostek text-n-800 font-semibold'>Genuine Parts </a>
                </div>

                <div class="hidden md:flex items-center md:gap-x-12 md:mr-5" >
                    <a href='#' className='font-grostek font-bold text-n-800 border border-p-500 rounded-xl px-4 py-2 inline-block hover:bg-p-500 hover:text-n-50 '>Login here <span>&rarr;</span></a>
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