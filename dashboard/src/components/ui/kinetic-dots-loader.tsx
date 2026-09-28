'use client';

import React from 'react';

export default function KineticDotsLoader({
  size = 20,
  label = 'Loading platform telemetry...',
}: {
  size?: number;
  label?: string;
}) {
  const dots = 4;

  return (
    <div className="flex flex-col items-center justify-center p-6 select-none">
      <div className="flex gap-4 items-end h-16">
        {[...Array(dots)].map((_, i) => (
          <div
            key={i}
            className="relative flex flex-col items-center justify-end h-14 w-5"
          >
            {/* 1. THE BOUNCING DOT */}
            <div
              className="relative w-4 h-4 z-10"
              style={{
                animation: 'gravity-bounce 1.4s cubic-bezier(0.45, 0.05, 0.55, 0.95) infinite',
                animationDelay: `${i * 0.15}s`,
                willChange: 'transform',
              }}
            >
              <div
                className="w-full h-full rounded-full bg-gradient-to-b from-cyan-300 to-blue-600 shadow-[0_0_12px_rgba(6,182,212,0.6)]"
                style={{
                  animation: 'rubber-morph 1.4s linear infinite',
                  animationDelay: `${i * 0.15}s`,
                  willChange: 'transform',
                }}
              />
              {/* Specular highlight */}
              <div className="absolute top-0.5 left-0.5 w-1.5 h-1.5 bg-white/70 rounded-full blur-[0.5px]" />
            </div>

            {/* 2. FLOOR RIPPLE */}
            <div
              className="absolute bottom-0 w-8 h-2 border border-cyan-400/40 rounded-full opacity-0"
              style={{
                animation: 'ripple-expand 1.4s linear infinite',
                animationDelay: `${i * 0.15}s`,
              }}
            />

            {/* 3. REFLECTIVE SHADOW */}
            <div
              className="absolute -bottom-0.5 w-4 h-1 rounded-full bg-cyan-500/40 blur-[1px]"
              style={{
                animation: 'shadow-breathe 1.4s cubic-bezier(0.45, 0.05, 0.55, 0.95) infinite',
                animationDelay: `${i * 0.15}s`,
              }}
            />
          </div>
        ))}
      </div>

      {label && (
        <p className="mt-3 text-xs font-semibold tracking-wide text-cyan-800">
          {label}
        </p>
      )}

      <style jsx>{`
        @keyframes gravity-bounce {
          0% { transform: translateY(0); animation-timing-function: cubic-bezier(0.33, 1, 0.68, 1); }
          50% { transform: translateY(-30px); animation-timing-function: cubic-bezier(0.32, 0, 0.67, 0); }
          100% { transform: translateY(0); }
        }
        @keyframes rubber-morph {
          0% { transform: scale(1.35, 0.65); }
          5% { transform: scale(0.9, 1.1); }
          15% { transform: scale(1, 1); }
          50% { transform: scale(1, 1); }
          85% { transform: scale(0.9, 1.1); }
          100% { transform: scale(1.35, 0.65); }
        }
        @keyframes shadow-breathe {
          0% { transform: scale(1.35); opacity: 0.55; }
          50% { transform: scale(0.5); opacity: 0.12; }
          100% { transform: scale(1.35); opacity: 0.55; }
        }
        @keyframes ripple-expand {
          0% { transform: scale(0.5); opacity: 0; border-width: 3px; }
          5% { opacity: 0.7; }
          30% { transform: scale(1.4); opacity: 0; border-width: 0px; }
          100% { transform: scale(1.4); opacity: 0; }
        }
      `}</style>
    </div>
  );
}
