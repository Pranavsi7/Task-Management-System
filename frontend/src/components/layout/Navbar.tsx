'use client';

import { useAuth } from '@/hooks/useAuth';
import { useRouter } from 'next/navigation';
import { CheckSquare, LogOut, User } from 'lucide-react';

export default function Navbar() {
  const { user, logout } = useAuth();
  const router = useRouter();

  const handleLogout = async () => {
    await logout();
    router.push('/auth/login');
  };

  return (
    <nav
      className="sticky top-0 z-40 flex items-center justify-between px-6 py-3.5"
      style={{
        background: 'rgba(255,255,255,0.85)',
        backdropFilter: 'blur(12px)',
        borderBottom: '1px solid var(--border)',
      }}
    >
      <div className="flex items-center gap-2" style={{ color: 'var(--brand)' }}>
        <CheckSquare size={22} />
        <span className="text-base font-bold tracking-tight" style={{ color: 'var(--text-primary)' }}>TaskFlow</span>
      </div>

      <div className="flex items-center gap-3">
        <div className="hidden sm:flex items-center gap-2 text-sm" style={{ color: 'var(--text-secondary)' }}>
          <User size={14} />
          <span>{user?.name}</span>
        </div>
        <button onClick={handleLogout} className="btn-ghost py-1.5 px-3 text-xs gap-1.5">
          <LogOut size={13} />
          Logout
        </button>
      </div>
    </nav>
  );
}
