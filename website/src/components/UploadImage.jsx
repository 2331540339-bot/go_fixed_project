import {useRef, useState} from 'react'

function UploadImage(){
  const fileInputRef = useRef(null);
  const [preview, setPreview] = useState(null);
  const[check, setCheck] = useState(false);
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if(file){
      const imageURL = URL.createObjectURL(file);
      setPreview(imageURL);
      setCheck(true)
    }
  }
  return(
    <>
      <div className=' h-70'>
        <input
          type='file'
          accept='image/*' 
          ref = {fileInputRef}
          onChange={handleFileChange}
          className={check ? "hidden": "self-center px-4 py-2 text-center border h-15 rounded-2xl font-grostek text-n-50 border-n-50"}
        /> 
        {preview && (<img src={preview} className='w-auto px-4 py-2 h-70 rounded-2xl bg-n-50'/>)}
      </div>
      
    </>
  )
}export default UploadImage