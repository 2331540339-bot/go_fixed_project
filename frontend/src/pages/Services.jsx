import { useEffect, useState } from "react";
import api from "../app/apiClient";
import Loading from "../components/Loading";
import ServiceCard from "../components/ServiceCard";

export default function Services() {
  const [services, setServices] = useState([]);
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const { data } = await api.get("/service/get"); // GET /service
        if (mounted) setServices(Array.isArray(data) ? data : data?.services || []);
      } catch (e) {
        console.error(e);
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, []);

  const filtered = services.filter(s =>
    (s?.name || "").toLowerCase().includes(q.toLowerCase()) ||
    (s?.description || "").toLowerCase().includes(q.toLowerCase())
  );

  if (loading) return <Loading label="Fetching services..." />;

  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-2xl font-bold">Services</h2>
        <input
          className="w-64 rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-brand-500"
          placeholder="Search services..."
          value={q}
          onChange={(e) => setQ(e.target.value)}
        />
      </div>

      {filtered.length === 0 ? (
        <p className="text-gray-500">No services found.</p>
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map(s => <ServiceCard key={s._id || s.id} service={s} />)}
        </div>
      )}
    </section>
  );
}
