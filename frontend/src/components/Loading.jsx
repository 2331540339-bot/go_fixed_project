export default function Loading({ label = "Loading..." }) {
  return (
    <div className="flex items-center justify-center py-20">
      <div className="animate-spin h-6 w-6 border-2 border-gray-300 border-t-brand-500 rounded-full mr-3" />
      <span className="text-gray-600">{label}</span>
    </div>
  );
}
