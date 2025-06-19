'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import toast from 'react-hot-toast';
import Link from 'next/link';
import '../styles/LoginModal.css';
import { useAuth } from '@/context/AuthContext';


export default function LoginModal({ onClose }) {
  const t = useTranslations('Login');

  const { login } = useAuth();
  const [form, setForm] = useState({ email: '', password: '' });

  const handleChange = (e) => {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    toast.loading(t('loading'), { id: 'login' });

    const res = await fetch('http://localhost:5000/api/auth/login', {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form)
    });

    if (res.ok) {
        await login();
        toast.success(t('success'), { id: 'login' });
        onClose();
        } else {
        const data = await res.json();
        toast.error(data?.error || t('error'), { id: 'login' });
    }
    };

  return (
    <div className="login-modal">
      <div className="modal-content">
        <button className="close-btn" onClick={onClose}>×</button>
        <h2>{t('title')}</h2>
        <form onSubmit={handleSubmit}>
          <input
            name="email"
            type="email"
            placeholder={t('email')}
            value={form.email}
            onChange={handleChange}
            required
          />
          <input
            name="password"
            type="password"
            placeholder={t('password')}
            value={form.password}
            onChange={handleChange}
            required
          />
          <button type="submit" className="submit-btn">{t('login')}</button>
        </form>
        <p className="link-text">
          {t('noAccount')}{' '}
          <Link href="/register" onClick={onClose}>{t('signupLink')}</Link>
        </p>
      </div>
    </div>
  );
}
