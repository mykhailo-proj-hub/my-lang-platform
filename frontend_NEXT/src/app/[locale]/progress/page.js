'use client';

import { useEffect, useState } from 'react';
import { useTranslations } from 'next-intl';
import ProtectedRoute from '@/components/ProtectedRoute';
import styles from './page.module.css';

export default function ProgressPage() {
  const t = useTranslations('Progress');
  const [data, setData] = useState(null);

  useEffect(() => {
    const mockData = {
      chatsCreated: 20,
      messagesSent: 350,
      averageDuration: '15 min',
      recommendedTopics: ['AI', 'Technology'],
      weeklyTargets: {
        newTopics: 5,
        unanswered: 3,
      },
      totalSessions: 8,
      correctAnswers: 37,
      incorrectAnswers: 13,
      lastPracticeDate: '2025-05-10',
    };
    setData(mockData);
  }, []);

  return (
    
    <ProtectedRoute>
      <div className={styles.wrapper}>
      <div className={styles.progressPage}>
        <section className={styles.analyticsSection}>
          <div className={styles.analyticsBox}>
            <h2 className={styles.sectionTitle}>{t('chatAnalyticsTitle')}</h2>
            <p><strong>{t('chatsCreated')}:</strong> {data?.chatsCreated}</p>
            <p><strong>{t('messagesSent')}:</strong> {data?.messagesSent}</p>
            <p><strong>{t('averageDuration')}:</strong> {data?.averageDuration}</p>
          </div>

          <div className={styles.recommendationsBox}>
            <h2 className={styles.sectionTitle}>{t('recommendationsTitle')}</h2>
            <p>{t('weeklyTarget', { count: data?.weeklyTargets?.newTopics })}</p>
            <p>{t('unansweredTarget', { count: data?.weeklyTargets?.unanswered })}</p>
            <p>{t('focusTopics')}: <strong>{data?.recommendedTopics.join(', ')}</strong></p>
          </div>
        </section>

        <section className={styles.practiceStatsSection}>
          <h2 className={styles.sectionTitle}>{t('practiceStatsTitle')}</h2>
          <div className={styles.statsBox}>
            <div className={styles.statItem}>
              <h3>🔁 {t('sessions')}</h3>
              <p>{data?.totalSessions}</p>
            </div>
            <div className={styles.statItem}>
              <h3>✅ {t('correct')}</h3>
              <p>{data?.correctAnswers}</p>
            </div>
            <div className={styles.statItem}>
              <h3>❌ {t('incorrect')}</h3>
              <p>{data?.incorrectAnswers}</p>
            </div>
            <div className={styles.statItem}>
              <h3>📅 {t('lastSession')}</h3>
              <p>{data?.lastPracticeDate}</p>
            </div>
          </div>
        </section>

        <section className={styles.achievementsSection}>
          <h2 className={styles.sectionTitle}>{t('achievementsTitle')}</h2>
          <div className={styles.achievementList}>
            <p>💬 1000+ {t('messagesAchievement')}</p>
            <p>🟢 {t('activeUser')}</p>
          </div>
        </section>
      </div>
    </div>
    </ProtectedRoute>
  );
}
