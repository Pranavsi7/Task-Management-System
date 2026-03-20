'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuth } from '@/hooks/useAuth';
import toast from 'react-hot-toast';
import { UserPlus, CheckSquare } from 'lucide-react';

const schema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Enter a valid email'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  confirm: z.string(),
}).refine((d) => d.password === d.confirm, { message: "Passwords don't match", path: ['confirm'] });
type FormData = z.infer<typeof schema>;

export default function RegisterPage() {
  const { register: registerUser } = useAuth();
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    setSubmitting(true);
    try {
      await registerUser(data.name, data.email, data.password);
      router.push('/dashboard');
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Registration failed';
      toast.error(msg);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-8" style={{ background: 'var(--bg)' }}>
      <div className="w-full max-w-sm">
        <div className="flex items-center gap-2 mb-8" style={{ color: 'var(--brand)' }}>
          <CheckSquare size={24} />
          <span className="text-lg font-bold">TaskFlow</span>
        </div>

        <h1 className="text-2xl font-bold mb-1" style={{ color: 'var(--text-primary)' }}>Create account</h1>
        <p className="text-sm mb-8" style={{ color: 'var(--text-secondary)' }}>Get started for free</p>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Full Name</label>
            <input {...register('name')} className="input" placeholder="Jane Doe" />
            {errors.name && <p className="text-xs mt-1" style={{ color: 'var(--danger)' }}>{errors.name.message}</p>}
          </div>
          <div>
            <label className="label">Email</label>
            <input {...register('email')} type="email" className="input" placeholder="you@example.com" />
            {errors.email && <p className="text-xs mt-1" style={{ color: 'var(--danger)' }}>{errors.email.message}</p>}
          </div>
          <div>
            <label className="label">Password</label>
            <input {...register('password')} type="password" className="input" placeholder="Min. 6 characters" />
            {errors.password && <p className="text-xs mt-1" style={{ color: 'var(--danger)' }}>{errors.password.message}</p>}
          </div>
          <div>
            <label className="label">Confirm Password</label>
            <input {...register('confirm')} type="password" className="input" placeholder="••••••••" />
            {errors.confirm && <p className="text-xs mt-1" style={{ color: 'var(--danger)' }}>{errors.confirm.message}</p>}
          </div>
          <button type="submit" disabled={submitting} className="btn-primary w-full justify-center mt-2">
            {submitting ? <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" /> : <UserPlus size={16} />}
            {submitting ? 'Creating account…' : 'Create Account'}
          </button>
        </form>

        <p className="text-sm text-center mt-6" style={{ color: 'var(--text-secondary)' }}>
          Already have an account?{' '}
          <Link href="/auth/login" style={{ color: 'var(--brand)', fontWeight: 600 }}>Sign in</Link>
        </p>
      </div>
    </div>
  );
}
