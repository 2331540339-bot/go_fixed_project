import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import api from "../app/apiClient";
import Loading from "../components/Loading";

export default function ServiceDetail() {
  const { id } = useParams();
  const [service, setService] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const { data } = await api.get(`/service/${id}`);
        if (mounted) setService(data?.service || data);
      } catch (e) {
        console.error(e);
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    return () => { mounted = false; };
  }, [id]);

  if (loading) return <Loading label="Loading service..." />;

  if (!service) return <p className="text-gray-500">Service not found.</p>;

  return (
    <article className="grid md:grid-cols-5 gap-6">
      <div className="md:col-span-3 card p-4">
        <img
          src={service.image || "https://images.unsplash.com/photo-1489769002049-ccd828976a6c?q=80&w=2069&auto=format&fit=crop"}
          alt={service.name}
          className="rounded-xl w-full h-72 object-cover"
        />
      </div>
      <div className="md:col-span-2 space-y-4">
        <h1 className="text-2xl font-bold">{service.name}</h1>
        <p className="text-gray-600">{service.description}</p>
        <div className="flex items-center gap-3">
          <span className="text-xl font-semibold text-brand-600">
            {service.price ? `$${service.price}` : "Contact"}
          </span>
          <span className="text-sm px-2 py-1 rounded bg-brand-50 text-brand-700">
            {service.category || "General"}
          </span>
        </div>
        <button className="btn-primary">Book now</button>
      </div>
    </article>
  );
}
