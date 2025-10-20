import { createBrowserRouter } from "react-router-dom"
import App from "../App"
import Home from "../pages/Home"
import Services from "../pages/Services"

export const router = createBrowserRouter([
    {
        path:"/",
        element:<App/>,
        children:[
            {index:true , element: <Home/>},
            {path:"services", element: <Services/> }
        ]
    }
])