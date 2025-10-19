export default function Footer() {
  return (
    <footer className="border-t">
      <div className="container mx-auto max-w-6xl px-4 py-8 text-sm text-gray-500 flex items-center justify-between">
        <p>© {new Date().getFullYear()} GoFix Project</p>
        <p className="hidden sm:block">Built with React + Tailwind</p>
      </div>
    </footer>
  );
}
