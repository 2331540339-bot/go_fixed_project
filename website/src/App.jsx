import Header from "./components/Header"
import { Outlet } from "react-router-dom"
import Footer from "./components/Footer"
function App() {
  return (
    <>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap');
      </style>
      <Header/>
      <Outlet/>
      <Footer/>
    </>
  )
}

export default App
