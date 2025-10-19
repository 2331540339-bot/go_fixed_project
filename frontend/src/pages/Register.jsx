import { useState } from "react";
import api from "../app/apiClient";
import { useNavigate } from "react-router-dom";

export default function Register() {
  const nav = useNavigate();
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [err, setErr] = useState("");

  const onSubmit = async (e) => {
    e.preventDefault();
    setErr("");
    try {
      await api.post("/account/register", form);
      nav("/login");
    } catch (e) {
      console.error(e);
      setErr(e.response?.data?.message || "Register failed");
    }
  };

  return (
    <div className="max-w-md mx-auto card p-6">
      <h2 className="text-xl font-semibold mb-4">Create account</h2>
      <form className="space-y-3" onSubmit={onSubmit}>
        <input
          className="w-full rounded-xl border px-3 py-2"
          placeholder="Full name"
          value={form.name}
          onChange={(e) => setForm(f => ({...f, name: e.target.value}))}
        />
        <input
          className="w-full rounded-xl border px-3 py-2"
          placeholder="Email"
          type="email"
          value={form.email}
          onChange={(e) => setForm(f => ({...f, email: e.target.value}))}
        />
        <input
          className="w-full rounded-xl border px-3 py-2"
          placeholder="Password"
          type="password"
          value={form.password}
          onChange={(e) => setForm(f => ({...f, password: e.target.value}))}
        />
        {err && <p className="text-sm text-red-600">{err}</p>}
        <button className="btn-primary w-full">Register</button>
      </form>
    </div>
  );
}
