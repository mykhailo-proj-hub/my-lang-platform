'use client';

import React, { useEffect, useState } from 'react';
import ProtectedRoute from '@/components/ProtectedRoute';
import useDailyPractice from './components/useDailyPractice';
import PracticeCard from './components/PracticeCard';
import { useTranslations } from 'next-intl';
import { apiUrl } from '@/lib/api';
import styles from './page.module.css';

export default function PracticePage() {
  const [submitted, setSubmitted] = useState(false);
  const [showReview, setShowReview] = useState(true);
  const [finished, setFinished] = useState(false);
  const t = useTranslations('PracticeRoom');

  const {
    tasks,
    loading,
    error,
    currentIndex,
    currentTask,
    nextTask,
    prevTask,
    isLast,
    resetIndex,
    reset,
  } = useDailyPractice();

  
  const score = tasks.filter(t => t.answer === t.correct).length;
  
  const markAsFinished = () => {
    if (!finished) {
      setFinished(true);
    }
  };

  useEffect(() => {
    const allAnswered = tasks.length > 0 && tasks.every(t => t.answer !== null);
    if (allAnswered) {
      setFinished(true);
      console.log('✅ finished',finished);
    }
  }, [tasks]);
  
  // ⛳ Автоматичне збереження при завершенні
  useEffect(() => {
    if (finished && !submitted) {
      handleAutoSaveResult();
    }
  }, [finished]);

  const handleShowResult = () => {
    setShowReview(true);
    console.log('✅ showReview',showReview, '✅ finished',finished);

  };

  const handleShowAnswer = () => {
    resetIndex();
    setShowReview(false);
    setSubmitted(false);
  };

  const handleAutoSaveResult = async () => {
    if (submitted || tasks.length === 0) return;

    const answeredTasks = tasks.filter(t => t.answer !== null);
    if (answeredTasks.length !== tasks.length) return;

    const payload = {
      score,
      total: tasks.length,
      taskIds: answeredTasks.map(t => t.id),
    };

    try {
      const res = await fetch(apiUrl('/api/practice/save-final'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(payload),
      });

      const data = await res.json();

      if (data.success) {
        console.log('✅ Збережено та заархівовано:', data);
        setSubmitted(true);
      } else {
        console.warn('⚠️ Невдала архівація:', data);
      }
    } catch (err) {
      console.error('❌ Error saving progress:', err);
    }
  };

  const handleRegeneratePractice = async () => {
    try {
      const res = await fetch(apiUrl('/api/practice/clear-practice'), {
        method: 'POST',
        credentials: 'include',
      });
  
      const data = await res.json();
      if (data.success) {
        // Після очищення – регенеруємо нові
        setFinished(false);
        handleShowAnswer();
        reset();
      } else {
        console.warn('❗ Помилка при очищенні:', data);
      }
    } catch (err) {
      console.error('❌ Не вдалося очистити завдання:', err);
    }
  };


  return (
    <ProtectedRoute>
      {(finished && showReview) ? (
        <div className={styles.summary}>
          <h2>{t('completed')}</h2>
          <p>{t('score', { score, total: tasks.length })} 
            (<strong>{Math.round((score / tasks.length) * 100)}%</strong>)
          </p>

          <div className={styles.progressBarContainer}>
            <div
              className={styles.progressBar}
              style={{ width: `${(score / tasks.length) * 100}%` }}
            ></div>
          </div>

          <p className={styles.feedback}>
            {score === tasks.length && t('feedback.perfect')}
            {score >= tasks.length * 0.8 && score < tasks.length && t('feedback.good')}
            {score >= tasks.length * 0.5 && score < tasks.length * 0.8 && t('feedback.average')}
            {score < tasks.length * 0.5 && t('feedback.poor')}
          </p>

          <div className={styles.summaryButtons}>
            <button onClick={handleShowAnswer}>{t('reviewAnswers')}</button>
            <button onClick={handleRegeneratePractice}>{t('morePractice')}</button> 
          </div>
        </div>
      ) : (
        <div className={styles.wrapper}>
          {loading && <p className={styles.loading}>🔄 {t('loading')}</p>}
          {error && <p className={styles.error}>❌ {t('error')}: {error}</p>}

          {!loading && !error && !currentTask && (
            <p className={styles.info}>ℹ️ {t('noTasks')}</p>
          )}
  
          {!loading && currentTask && (
            <PracticeCard
              task={currentTask}
              taskIndex={currentIndex}
              total={tasks.length}
              onNext={nextTask}
              onPrev={prevTask}
              onFinish={handleShowResult}
              isLast={isLast}
              markAsFinished={markAsFinished}
            />
          )}
        </div>
      )}
    </ProtectedRoute>
  );
}
