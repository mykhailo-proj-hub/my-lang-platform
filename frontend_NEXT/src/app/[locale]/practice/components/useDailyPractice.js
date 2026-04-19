import { useEffect, useState, useCallback } from 'react';
import { apiUrl } from '@/lib/api';

export default function useDailyPractice() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentIndex, setCurrentIndex] = useState(0);

  const fetchTasks = useCallback(async () => {
    try {
      setLoading(true);
      const res = await fetch(apiUrl('/api/practice/getDailyPractice'), {
        credentials: 'include',
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        const msg = data?.error || `HTTP ${res.status}`;
        throw new Error(msg);
      }

      const data = await res.json();
      if (!Array.isArray(data.tasks)) {
        throw new Error('Невірний формат відповіді від сервера');
      }

      setTasks(data.tasks);
      setError(null);
    } catch (err) {
      console.error('[useDailyPractice] error:', err);
      setError(err.message || 'Сталася помилка при завантаженні завдань');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTasks();
  }, [fetchTasks]);

  const nextTask = () => {
    if (currentIndex < tasks.length - 1) {
      setCurrentIndex((prev) => prev + 1);
      reset();
    }
  };

  const prevTask = () => {
    if (currentIndex > 0) {
      setCurrentIndex((prev) => prev - 1);
      reset();

    }
  };

  const reset = () => {
    fetchTasks();
  };

  return {
    tasks,
    loading,
    error,
    currentIndex,
    currentTask: tasks[currentIndex],
    nextTask,
    prevTask,
    isLast: currentIndex === tasks.length - 1,
    resetIndex: () => setCurrentIndex(0),
    reset,
  };
}
