import { useState } from "react";
import api from "../app/apiClient";
import { useNavigate, Link } from "react-router-dom";

export default function Login() {
  const nav = useNavigate();
  const [form, setForm] = useState({ email: "", password: "" });
  const [err, setErr] = useState("");

  const onSubmit = async (e) => {
    e.preventDefault();
    setErr("");
    try {
      const { data } = await api.post("/account/login", form);
      if (data?.token) localStorage.setItem("access_token", data.token);
      nav("/");
    } catch (e) {
      console.error(e);
      setErr(e.response?.data?.message || "Login failed");
    }
  };

  return (
    <div className="max-w-md mx-auto card p-6">
      <h2 className="text-xl font-semibold mb-4">Sign in</h2>
      <form className="space-y-3" onSubmit={onSubmit}>
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
        <button className="btn-primary w-full">Login</button>
      </form>
      <p className="text-sm text-gray-600 mt-3">
        No account? <Link className="text-brand-600" to="/register">Register</Link>
      </p>
    </div>
  );
}
