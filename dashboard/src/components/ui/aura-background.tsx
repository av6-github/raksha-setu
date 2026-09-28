'use client';

import React from 'react';

interface AuraBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export function AuraBackground({ children, className = '', style }: AuraBackgroundProps) {
  return (
    <div
      className={`aura-bg ${className}`}
      style={{
        position: 'relative',
        overflow: 'hidden',
        minHeight: '100vh',
        /* NO backgroundColor - blend modes composite against body/page bg (#FAF8F2) */
        ...style,
      }}
    >
      {/* Layer 1 - normal */}
      <div
        className="aura-layer-1"
        aria-hidden="true"
      />
      {/* Layer 2 - multiply */}
      <div
        className="aura-layer-2"
        aria-hidden="true"
      />
      {/* Layer 3 - multiply */}
      <div
        className="aura-layer-3"
        aria-hidden="true"
      />
      {/* Layer 4 - multiply */}
      <div
        className="aura-layer-4"
        aria-hidden="true"
      />

      {/* Page content lives here - wrapper sits ABOVE the layers with z-index: 1 */}
      <div style={{ position: 'relative', zIndex: 1 }} className="w-full min-h-screen">
        {children}
      </div>
    </div>
  );
}

export default AuraBackground;
