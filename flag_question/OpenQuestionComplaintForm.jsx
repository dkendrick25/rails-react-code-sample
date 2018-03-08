import React from 'react'
import PropTypes from 'prop-types'


const OpenQuestionComplaintForm = ({ handleSubmit, handleOnChange, handleCancel, reasons }) => (
  <div>
    <p>Flag The Question Above</p>
    <form onSubmit={(e) => handleSubmit(e)}>
      <div className="form-group">
        <select name='reason' className="form-control" onChange={(e) => handleOnChange(e)}>
          { reasons.map( (r, i) => {
              return <option key={i} value={r.reason}>{r.text}</option>
            })  
          }
        </select>
      </div>
      <div className="form-group">
        <textarea name='description' className="form-control" type="text" placeholder="Please describe the issue or change needed" rows="5" onChange={(e) => handleOnChange(e)}></textarea>
      </div>
      <input className="button button--primary btn-block" type="submit" value="Submit" />
    </form>
    <button className="button btn-link quiz-start__button" onClick={() => handleCancel()}>Cancel</button>
  </div>
)

OpenQuestionComplaintForm.propTypes = {
  handleSubmit:   PropTypes.func.isRequired,
  handleOnChange: PropTypes.func.isRequired,
  handleCancel:   PropTypes.func.isRequired,
  reasons:        PropTypes.array.isRequired
}

export default OpenQuestionComplaintForm