// src/components/UploadImage.jsx
import { useState } from "react";

function UploadImage({ onChange }) {
    const [preview, setPreview] = useState([]);

    const handleUpload = async (e) => {
        const files = Array.from(e.target.files);
        const uploadedUrls = [];

        for (let file of files) {
            const formData = new FormData();
            formData.append("file", file);
            formData.append("upload_preset", "gofix_upload");

            const res = await fetch(
                "https://api.cloudinary.com/v1_1/<cloud_name>/image/upload",
                {
                    method: "POST",
                    body: formData,
                }
            );
            const data = await res.json();
            uploadedUrls.push(data.secure_url);
        }

        // lưu ảnh preview
        setPreview(uploadedUrls);

        // trả URL lên cha
        if (onChange) onChange(uploadedUrls);
    };

    return (
        <div className="flex flex-col">
            <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleUpload}
                className="text-white"
            />

            <div className="flex gap-2 mt-3">
                {preview.map((img, index) => (
                    <img
                        key={index}
                        src={img}
                        alt="preview"
                        className="w-20 h-20 rounded-lg object-cover border border-gray-500"
                    />
                ))}
            </div>
        </div>
    );
}

export default UploadImage;
