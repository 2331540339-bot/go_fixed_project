import Header from "./components/Header"
import { Outlet } from "react-router-dom"
import Footer from "./components/Footer"
import Chatbot from './components/Chatbot';
import { useState } from "react"
function App() {
  const [authChange, setAuthChange] = useState(0);
  const checkAuthChange = () => {
    setAuthChange(prev => prev + 1);
  }
  console.log(authChange)
  return (
    <>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300..700&display=swap');
      </style>
      <Header onAuthChange = {checkAuthChange}/>
      <Outlet key = {authChange}/>
      <Chatbot />
      <Footer/>
      
    </>
  )
}

export default App
