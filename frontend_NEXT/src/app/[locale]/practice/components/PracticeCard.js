import React, { useState, useEffect } from 'react';
import { useTranslations } from 'next-intl';
import './styles/PracticeCard.css';

export default function PracticeCard({
  task,
  taskIndex,
  total,
  onNext,
  onPrev,
  onFinish,
  isLast,
  markAsFinished 
}) {
  const [selected, setSelected] = useState(null);
  const [answered, setAnswered] = useState(false);
  const t = useTranslations('PracticeRoom');

  useEffect(() => {
    setSelected(task.answer ?? null);
    setAnswered(Boolean(task.answer));
  }, [task.id]);

  const handleSelect = async (option) => {
    if (!answered) {
      setSelected(option);
      setAnswered(true);
  
      try {
        await fetch('http://localhost:5000/api/practice/save-answer', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            taskId: task.id,
            answer: option,
          }),
          credentials: 'include',
        });
        
        if (isLast) {
          markAsFinished?.(); // 🆕 Явне завершення практики
        }
      } catch (err) {
        console.error('❌ Не вдалося зберегти відповідь:', err);
      }
    }
  };

  return (
    <div className="practice-card">
      <div className="practice-card-header">
        {t('task')} {taskIndex + 1} / {total}
      </div>

      {task.theory && (
        <div className="practice-theory">
          <h4>📘 {task.theory?.title?.replace(/^Title:\s*/i, '') || ''}</h4>
          <p>{task.theory.content}</p>
        </div>
      )}

      <div className="practice-question">{task.question}</div>
      
      <div className="practice-options">
      {task.options.map((option, idx) => {
        let className = 'practice-option';
        if (answered) {
          if (option === task.correct) className += ' correct';
          else if (option === selected) className += ' incorrect';
        } else if (option === selected) className += ' selected';
        

        return (
          <button
            key={idx}
            onClick={() => handleSelect(option)}
            disabled={answered}
            className={className}
          >
            {option}
          </button>
        );
      })}
      </div>

      {answered && (
        <div className="practice-explanation">
          ✅ {task.explanation}
        </div>
      )}
      <div className="practice-footer">
        <button onClick={onPrev} disabled={taskIndex === 0}>
          ◀ {t('prev')}
        </button>
        
        {isLast ? (
          answered ? (
            <button onClick={onFinish}>{t('finish')}</button>
          ) : (
            <button disabled>{t('selectAnswer')}</button>
          )
        ) : (
          <button onClick={onNext} disabled={!answered}>
            {t('next')} ▶
          </button>
        )}
      </div>
    </div>
  );
}
