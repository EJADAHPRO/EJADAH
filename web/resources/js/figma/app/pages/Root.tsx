import { Outlet, ScrollRestoration } from "react-router";
import { Navbar, Footer, globalStyle } from "@/figma/app/shared";

export default function Root() {
  return (
    <>
      <style>{globalStyle}</style>
      <div style={{ minHeight: "100vh", display: "flex", flexDirection: "column" }}>
        <Navbar />
        <main style={{ flex: 1 }}>
          <Outlet />
        </main>
        <Footer />
      </div>
      <ScrollRestoration />
    </>
  );
}
