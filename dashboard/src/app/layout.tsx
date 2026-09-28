import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "RakshaSetu - Command, Welfare & Family Portal",
  description: "Armed Forces Welfare, Operational Resilience & Veer Parivar Support Platform.",
  icons: {
    icon: "/rakshasetu_logo.png",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/rakshasetu_logo.png" />
      </head>
      <body
        className="min-h-screen bg-[#faf8f2] text-[#0A1F2C] selection:bg-cyan-200"
        suppressHydrationWarning
      >
        {children}
      </body>
    </html>
  );
}
