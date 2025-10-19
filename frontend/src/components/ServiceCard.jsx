import { Link } from "react-router-dom";

export default function ServiceCard({ service }) {
  return (
    <div className="card p-4 flex flex-col gap-3">
      <div className="flex items-start justify-between gap-2">
        <h3 className="text-lg font-semibold">{service?.name || "Service"}</h3>
        <span className="text-sm px-2 py-1 rounded bg-brand-50 text-brand-700">
          {service?.category || "General"}
        </span>
      </div>
      <p className="text-sm text-gray-600 line-clamp-3">
        {service?.description || "No description"}
      </p>
      <div className="flex items-center justify-between">
        <span className="font-semibold text-brand-600">
          {service?.price ? `$${service.price}` : "Contact"}
        </span>
        <Link to={`/services/${service?._id || service?.id}`} className="btn-primary">
          View
        </Link>
      </div>
    </div>
  );
}
