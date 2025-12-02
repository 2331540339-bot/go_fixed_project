import { createBrowserRouter } from "react-router-dom"
import App from "../App"
import Home from "../pages/Home"
import Services from "../pages/Services"
import ServiceBooking from "../pages/ServiceBooking"    
import GenuinePart from "../pages/GenuinePart"
import AllPart from "../components/AllPart"
import DetailPart from "../pages/DetailPart"
import Checkout from "../components/Checkout"
import Cart from "../pages/Cart"
import SuccessPayment from "../components/SuccessPayment"
import FailedPayment from "../components/FailedPayment"
import Register from "../pages/Register"
import Order from "../pages/OrderPage"
export const router = createBrowserRouter([
    {
        path:"/",
        element:<App/>,
        children:[
            {index:true , element: <Home/>},
            {path:"register", element: <Register/> },
            {path:"services", element: <Services/> },
            {path:"services/:id", element: <ServiceBooking/> },
            {path:"genuine-part", element: <GenuinePart/>},
            {path:"genuine-part/all-product", element: <AllPart/>},
            {path:"genuine-part/:id", element: <DetailPart/>},
            {path:"/checkout/:productId/:quantity", element:<Checkout />},
            {path:"/cart", element: <Cart/>},
            {path:"/success-payment", element:<SuccessPayment />},
            {path:"/failed-payment", element:<FailedPayment />},
            {path:"/order", element:<Order />},
        ]
    }
])


